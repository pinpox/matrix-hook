package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/matrix-org/gomatrix"
	"github.com/prometheus/alertmanager/template"
)

func getMatrixMessageFor(alert template.Alert) gomatrix.HTMLMessage {
	var prefix string
	switch alert.Status {
	case "firing":
		prefix = "<strong><font color=\"#ff0000\">FIRING</font></strong> "
	case "resolved":
		prefix = "<strong><font color=\"#33cc33\">RESOLVED</font></strong> "
	default:
		prefix = fmt.Sprintf("<strong>%v</strong> ", alert.Status)
	}

	return gomatrix.GetHTMLMessage("m.text", prefix+alert.Labels["name"]+" >> "+alert.Annotations["summary"])
}

func getMatrixClient(homeserver string, user string, token string, targetRoomID string) *gomatrix.Client {
	log.Printf("Connecting to Matrix Homserver %v as %v.", homeserver, user)
	matrixClient, err := gomatrix.NewClient(homeserver, user, token)
	if err != nil {
		log.Fatalf("Could not log in to Matrix Homeserver (%v): %v", homeserver, err)
	}

	joinedRooms, err := matrixClient.JoinedRooms()
	if err != nil {
		log.Fatalf("Could not fetch Matrix rooms: %v", err)
	}

	alreadyJoinedTarget := false
	for _, roomID := range joinedRooms.JoinedRooms {
		if targetRoomID == roomID {
			alreadyJoinedTarget = true
		}
	}

	if alreadyJoinedTarget {
		log.Printf("%v is already part of %v.", user, targetRoomID)
	} else {
		log.Printf("Joining %v.", targetRoomID)
		_, err := matrixClient.JoinRoom(targetRoomID, "", nil)
		if err != nil {
			log.Fatalf("Failed to join %v: %v", targetRoomID, err)
		}
	}

	return matrixClient
}

func handleIncomingHooks(w http.ResponseWriter, r *http.Request,
	matrixClient *gomatrix.Client, targetRoomID string) {

	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	payload := template.Data{}
	if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
		w.WriteHeader(http.StatusBadRequest)
	}

	log.Printf("Received valid hook from %v", r.RemoteAddr)

	for _, alert := range payload.Alerts {
		msg := getMatrixMessageFor(alert)
		log.Printf("> %v", msg.Body)
		_, err := matrixClient.SendMessageEvent(targetRoomID, "m.room.message", msg)
		if err != nil {
			log.Printf(">> Could not forward to Matrix: %v", err)
		}
	}

	w.WriteHeader(http.StatusOK)
}

func main() {

	// Initialize Matrix client.
	matrixClient := getMatrixClient(
		os.Getenv("MX_HOMESERVER"),
		os.Getenv("MX_ID"),
		os.Getenv("MX_TOKEN"),
		os.Getenv("MX_ROOMID"),
	)

	// Initialize HTTP server.
	http.HandleFunc("/alert", func(w http.ResponseWriter, r *http.Request) {
		handleIncomingHooks(w, r, matrixClient, os.Getenv("MX_ROOMID"))
	})

	var listenAddr = fmt.Sprintf("%v:%v", os.Getenv("HTTP_ADDRESS"), os.Getenv("HTTP_PORT"))
	log.Printf("Listening for HTTP requests (webhooks) on %v", listenAddr)
	log.Fatal(http.ListenAndServe(listenAddr, nil))
}

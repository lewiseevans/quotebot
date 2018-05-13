package main

import (
	"encoding/json"
	"io"
	"math/rand"
	"net/http"
)

// Quote is a structure representing a quote
type Quote struct {
	Originator string   `json:"originator"` // Who said it
	Quote      string   `json:"quote"`      // What they said
	Tags       []string `json:"tags"`       // Any social media tags on this?
	Authentic  bool     `json:"authentic"`  // Is this an authentic quote?
}

// Writes the quote to the handler
func quote(w http.ResponseWriter, r *http.Request) {

	// get the quote from the store
	quote := getQuote()

	// turn it into JSON - TODO Funk this up a little
	bytes, err := json.Marshal(quote)
	if err != nil {
		io.WriteString(w, "OOOPS")
	}

	// Pipe it to the endpoint for consumption
	io.WriteString(w, string(bytes))
}

// Eventually this will do something interesting with a library of quotes
func getQuote() Quote {

	// Suitable selection of random quotes. TODO - look this up from a datastore
	sampleQuotes := []Quote{
		{
			Originator: "MrsE",
			Quote:      "You married the best woman in the world. Did you know that? I’m amazing.",
			Authentic:  true,
			Tags: []string{
				"thingsmrsesays",
				"ofcoursedear",
			},
		},
		{
			Originator: "MrsE",
			Quote:      "it’s important you don’t do that. Because I’ll want to smash your face in if you do.",
			Authentic:  true,
			Tags: []string{
				"thingsmrsesays",
			},
		},
		{
			Originator: "MrsE",
			Quote:      "\"You're like a dementor. You suck all the joy and happiness out of my life\" Knew watching harry potter was a mistake.",
			Authentic:  true,
			Tags: []string{
				"thingsmrsesays",
				"ofcoursedear",
			},
		},
		{
			Originator: "Abraham Lincoln",
			Quote:      "Don't believe everything you read on the internet.",
			Authentic:  false,
			Tags:       []string{},
		},
	}

	quoteToPick := rand.Intn(len(sampleQuotes))

	quote := sampleQuotes[quoteToPick]

	return quote
}

func main() {
	// Register the quotinator
	http.HandleFunc("/", quote)
	// Start this badboy up!
	http.ListenAndServe(":8080", nil)
}

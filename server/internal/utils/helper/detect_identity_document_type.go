package helper

import (
	"errors"
	"regexp"
	"strings"
)

// DetectIdentityDocumentType checks the document number and returns
// true if it's a 13-digit Thai citizen ID, false if it's a 9-char passport.
// Returns error if neither matches.
func DetectIdentityDocumentType(number string) (bool, error) {
	num := strings.TrimSpace(number)

	// 13 digits → citizen ID
	if matched, _ := regexp.MatchString(`^\d{13}$`, num); matched {
		return true, nil
	}

	// 9 alphanumeric with at least one letter → passport
	if matched, _ := regexp.MatchString(`^[A-Za-z0-9]{9}$`, num); matched {
		return false, nil
	}

	return false, errors.New("invalid identity document number format")
}

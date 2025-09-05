package v

import "time"

func TimePtrToRFC3339Ptr(t *time.Time) *string {
	if t == nil {
		return nil
	}
	s := t.UTC().Format(time.RFC3339)
	return Ptr(s)
}

package v

func IntValue(i *int) int {
	if i == nil {
		return 0
	}
	return *i
}

func UintValue(u *uint) uint {
	if u == nil {
		return 0
	}
	return *u
}

func StringValue(s *string) string {
	if s == nil {
		return ""
	}
	return *s
}

func BoolValue(b *bool) bool {
	if b == nil {
		return false
	}
	return *b
}

func Float64Value(f *float64) float64 {
	if f == nil {
		return 0
	}
	return *f
}

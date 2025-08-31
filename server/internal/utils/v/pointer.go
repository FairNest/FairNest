package v

func Ptr[T any](val T) *T {
	return &val
}

func UintPtr(val int) *uint {
	return Ptr(uint(val))
}

func UintToInt(u uint) int {
	return int(u)
}

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
		return 0.0
	}
	return *f
}
func UintToIntPtr(u *uint) *int {
	if u == nil {
		return nil
	}
	v := int(*u)
	return &v
}

func IntToUintPtr(i *int) *uint {
	if i == nil {
		return nil
	}
	v := uint(*i)
	return &v
}

func ByteSlice(s *string) []byte {
	if s == nil {
		return nil
	}
	return []byte(*s)
}

func FloatValue(f *float64) float64 {
	if f == nil {
		return 0
	}
	return *f
}

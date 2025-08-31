package v

func Ptr[T any](val T) *T {
	return &val
}

func UintPtr(val int) *uint {
	return Ptr(uint(val))
}

func IntValue(i *int) int {
	if i == nil {
		return 0 // or some default value you prefer
	}
	return *i
}

func UintValue(u *uint) uint {
	if u == nil {
		return 0
	}
	return *u
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

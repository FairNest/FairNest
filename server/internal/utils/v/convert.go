package v

func UintToInt(u uint) int {
	return int(u)
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

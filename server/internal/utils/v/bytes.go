package v

func ByteSlice(s *string) []byte {
	if s == nil {
		return nil
	}
	return []byte(*s)
}

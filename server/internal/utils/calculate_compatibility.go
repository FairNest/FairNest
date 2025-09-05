package utils

import (
	"fairnest/internal/entities"
	"fairnest/internal/utils/v"
)

func CalculateCompatibility(user entities.Lifestyle, room entities.Room) float64 {
	score := 0.0
	total := 0.0

	total++
	score += compatibilityScore(v.Float64Value(user.UserTidiness), v.Float64Value(room.AvgTidiness))

	total++
	score += compatibilityScore(v.Float64Value(user.UserNoiseActivity), v.Float64Value(room.AvgNoiseActivity))

	total++
	score += compatibilityScore(v.Float64Value(user.UserSchedule), v.Float64Value(room.AvgSchedule))

	total++
	score += compatibilityScore(v.Float64Value(user.UserGuestFrequency), v.Float64Value(room.AvgGuestFrequency))

	total++
	score += compatibilityScore(v.Float64Value(user.UserTaskStructure), v.Float64Value(room.AvgTaskStructure))

	total++
	score += compatibilityScore(v.Float64Value(user.UserMoneyAttitude), v.Float64Value(room.AvgMoneyAttitude))

	return score / total // average percent (0–100)
}

func compatibilityScore(userVal, roomVal float64) float64 {
	diff := abs(userVal - roomVal) // always 0.0 – 1.0
	score := (1.0 - diff) * 100.0  // closer → higher %
	if score < 0 {
		return 0
	}
	return score
}

func abs(x float64) float64 {
	if x < 0 {
		return -x
	}
	return x
}

package utils

import (
	"fairnest/internal/entities"
	"fairnest/internal/utils/v"
)

func CalculateCompatibility(user entities.Lifestyle, room entities.Room) float64 {
	score := 0.0
	total := 0.0

	total++
	score += compatibilityScore(v.FloatValue(user.UserTidiness), v.FloatValue(room.AvgTidiness))

	total++
	score += compatibilityScore(v.FloatValue(user.UserNoiseActivity), v.FloatValue(room.AvgNoiseActivity))

	total++
	score += compatibilityScore(v.FloatValue(user.UserSchedule), v.FloatValue(room.AvgSchedule))

	total++
	score += compatibilityScore(v.FloatValue(user.UserGuestFrequency), v.FloatValue(room.AvgGuestFrequency))

	total++
	score += compatibilityScore(v.FloatValue(user.UserTaskStructure), v.FloatValue(room.AvgTaskStructure))

	total++
	score += compatibilityScore(v.FloatValue(user.UserMoneyAttitude), v.FloatValue(room.AvgMoneyAttitude))

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

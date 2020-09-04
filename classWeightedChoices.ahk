class class_WeightedChoices
{
	aryChoices := []
	totalOdds := 0

AddChoice(strKey, intWeight)
	{
	this.totalOdds := this.totalOdds + intWeight
	this.aryChoices[strKey] := intWeight
	}

PickOne()
	{	
	strChoice := ""

	Random, randChoice, 1, this.totalOdds

	sumOddsSoFar := 0

	For keyIndex, weight in this.aryChoices
		{
		sumOddsSoFar := sumOddsSoFar + weight
		if (randChoice <= sumOddsSoFar)
			{
			strChoice := keyIndex
			break
			}
		}
	return strChoice
	}

}
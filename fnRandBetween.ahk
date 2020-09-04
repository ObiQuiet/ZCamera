RandBetween(min, max, fNormalDist=true)
	{
	if (fNormalDist)
		{
		halfmin := min/2
		halfmax := max/2
		Random, r1, halfmin, halfmax
		Random, r2, halfmin, halfmax
		return r1+r2
		}
	else
		{
		Random, r, %min%, %max%
		return r
		}

	}
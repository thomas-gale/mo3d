from testing import assert_equal

from collections import List

fn test_sort() raises:
	var l = List[Int](3, 2, 5, 1, 4)
	sort(l)
	assert_equal(l[0], 1)
	assert_equal(l[4], 5)

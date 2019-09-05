package main

import (
	"fmt"
	"sort"
	"strconv"
	"strings"
	"sync"
)

func concurrentSort(nums []int, wg *sync.WaitGroup) {
	fmt.Printf("Subarray to sort: %v\n", nums)
	sort.Ints(nums)
	wg.Done()
}

func merge(a1 []int, a2 []int) []int {
	merged := make([]int, 0)
	for len(a1) != 0 && len(a2) != 0 {
		if a1[0] < a2[0] {
			merged = append(merged, a1[0])
			a1 = a1[1:]
		} else {
			merged = append(merged, a2[0])
			a2 = a2[1:]
		}
	}
	if len(a1) == 0 {
		merged = append(merged, a2...)
	} else {
		merged = append(merged, a1...)
	}
	return merged
}

func main() {
	var input string

	fmt.Println("Enter a list of integers, each separated by a comma (e.g. '1,-2,3'):")
	fmt.Scanln(&input)

	numStrs := strings.Split(input, ",")
	nums := make([]int, len(numStrs))
	for idx, numStr := range numStrs {
		nums[idx], _ = strconv.Atoi(numStr)
	}

	quarter1 := nums[:len(nums)/4]
	quarter2 := nums[len(nums)/4 : len(nums)/2]
	quarter3 := nums[len(nums)/2 : 3*len(nums)/4]
	quarter4 := nums[3*len(nums)/4:]

	var wg sync.WaitGroup

	wg.Add(4)
	go concurrentSort(quarter1, &wg)
	go concurrentSort(quarter2, &wg)
	go concurrentSort(quarter3, &wg)
	go concurrentSort(quarter4, &wg)
	wg.Wait()

	half1 := merge(quarter1, quarter2)
	half2 := merge(quarter3, quarter4)
	full := merge(half1, half2)

	fmt.Printf("Full sorted list: %v\n", full)
}

package main

import (
"fmt"
"strings"

)
type Animals interface{
	Eat()
	Move()
	Sound()


}

type animal struct {
	food string
	locomotion string
	sound string
}

// This method means type T implements the interface I,
// but we don't need to explicitly declare that it does so.
func (t animal) Eat() {
	fmt.Println(t.food)
}
func (t animal) Move() {
	fmt.Println(t.locomotion)
}
func (t animal) Sound() {
	fmt.Println(t.sound)
}
type Cow struct{
     animal 
}
type Bird struct{
     animal 
}
type Snake struct{
     animal 
}

func indexOf(element string, data []string) (int) {
   for k, v := range data {
       if element == v {
           return k
       }
   }
   return -1    //not found.
}

func main() {

	var cow Cow = Cow{animal{"grass","walk","moo"}}
	var bird Bird = Bird{animal{"worms","fly","peep"}}
	var snake Snake = Snake{animal{"mice","slither","hiss"}}
	var animal_slice []Animals
	var name_slices []string
	animal_slice= append(animal_slice,cow)
	animal_slice= append(animal_slice,bird)
	animal_slice= append(animal_slice,snake)
	name_slices= append(name_slices,"cow")
	name_slices= append(name_slices,"bird")
	name_slices= append(name_slices,"snake")

	var query string

	fmt.Println("Enter your request by three strings separated for an space")

	var animal_type string
	var action string
	var currentAnimal Animals

	for {

		fmt.Print("> ")
		_, err := fmt.Scanf("%s %s %s",&query, &animal_type, &action)

		if err != nil {
			fmt.Println("Invalid input. Please enter your request")
			continue
		}
		if query == "query"{

			animal_type = strings.ToLower(animal_type)
			action = strings.ToLower(action)

			var index int = indexOf(animal_type,name_slices)

			var currentAnimal = animal_slice[index]

			if strings.Compare(action, "eat") == 0 {
				currentAnimal.Eat()
			} else if strings.Compare(action, "move") == 0 {
				currentAnimal.Move()
			} else if strings.Compare(action, "speak") == 0 {
				currentAnimal.Sound()
			} else {
				fmt.Println("Invalid action. Please input request again.")
				continue
			}

		}

	if query == "newanimal"{
	   if strings.Compare(action, "cow") == 0 {
				currentAnimal = cow
			} else if strings.Compare(action, "bird") == 0 {
				currentAnimal = bird
			} else if strings.Compare(action, "snake") == 0 {
				currentAnimal = snake
			} else {
				fmt.Println("Invalid animal. Please input request again.")
				continue
			}
	var animal_typer Animals = currentAnimal
	name_slices = append(name_slices,animal_type)
	animal_slice = append(animal_slice,animal_typer)
	fmt.Println("created it")

	
	}
}
}

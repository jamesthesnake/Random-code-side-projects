package main

import "fmt"
//specific
//Animal interface containg actions for each animal
type Animal interface {
	Eat()
	Move()
	Speak()
}

// Eat return food value for the Animal object
func (animal *AnimalType) Eat() {
	println(animal.food)
}

// Move return locomotion value for the Animal object
func (animal *AnimalType) Move() {
	println(animal.locomotion)
}

// Speak return noise value for the Animal object
func (animal *AnimalType) Speak() {
	println(animal.noise)
}

//Query print the value for each animal type
func Query(animal AnimalType, animalAction string) {
	switch animalAction {
	case "eat":
		animal.Eat()
	case "move":
		animal.Move()
	case "speak":
		animal.Speak()
	}
}

//FindAnimal return the animal type depending of its name
func FindAnimal(animalName string, zoo []AnimalType) AnimalType {
	var aa AnimalType
	for i := 0; i < len(zoo); i++ {
		aa := zoo[i]
		if (aa.name) == animalName {
			return zoo[i]
		}
	}
	return aa
}

//AnimalType is a object abstraction for an animal
type AnimalType struct {
	name       string
	food       string
	locomotion string
	noise      string
}

//CreateAnimal print the value for each animal type
func CreateAnimal(animalType string, AnimalName string) AnimalType {
	var animal AnimalType
	cow := AnimalType{AnimalName, "grass", "walk", "moop"}
	bird := AnimalType{AnimalName, "worms", "fly", "peep"}
	snake := AnimalType{AnimalName, "mice", "slither", "hsss"}
	switch animalType {
	case "cow":
		animal = cow
	case "bird":
		animal = bird
	case "snake":
		animal = snake
	}
	return animal
}

func main() {
	Zoo := []AnimalType{}
	var query, animalType, animalName string

	for 1 > 0 {
		print(">")
		fmt.Scanf("%s %s %s\n", &query, &animalName, &animalType)
		switch query {
		case "newanimal":
			Zoo = append(Zoo, CreateAnimal(animalType, animalName))
			println("Create it!")
		case "query":
			Query(FindAnimal(animalName, Zoo), animalType)
		}
	}
}

package main

import (
"fmt"
"strings"
"bufio"
"os"
)
type Animal struct {
	name string
	food string
	locomotion string
	sound string
}

func (animal_type Animal) Eat() string{

      return animal_type.food
}
func (animal_type Animal) Move() string{

      return animal_type.locomotion
}
func (animal_type Animal) Speak() string{

      return animal_type.sound
}





func get_animal(animal_name string) Animal  {
	if animal_name == "cow" {
		Cow := Animal{
		name : "Cow",
		food : "Grass",
		locomotion : "Walk",
		sound : "Moo",
		}	
		return Cow
	}
	if animal_name == "bird" {
		Bird := Animal{
		name : "Bird",
		food : "Worms",
		locomotion : "Fly",
		sound : "Peep",
		}	
		return Bird
	}
	if animal_name == "snake" {
		Snake := Animal{
		name : "Snake",
		food : "Mice",
		locomotion : "Slither",
		sound : "Hiss",
		}
		return Snake
	
	}
	Cow := Animal{
		name : "Cow",
		food : "Grass",
		locomotion : "Walk",
		sound : "Moo",
		}
	return Cow
} 
func get_animal_output(animal_name string, animal_action string){
	animal_type := get_animal(animal_name)
	if animal_action == "eat"{
	fmt.Println(animal_type.Eat())
	}
	if animal_action == "move"{
	fmt.Println(animal_type.Move())
	}
	if animal_action == "speak"{
	fmt.Println(animal_type.Speak())
	}
}

func repeat_entering(){
	reader := bufio.NewReader(os.Stdin)
	fmt.Print("Enter text: ")
	text, _ := reader.ReadString('\n')
	fmt.Println(text)
	text = strings.TrimSuffix(text, "\n")
	s := strings.Split(text, " ")
	strings.Replace(s[0], " ", "", -1)
	strings.Replace(s[1], " ", "", -1)
	animal_name := s[0]
	animal_action := s[1]
	get_animal_output(animal_name,animal_action)

}
func main(){
	for 1==1{
		repeat_entering()
	}
}

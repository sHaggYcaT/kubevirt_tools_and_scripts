package main

import (
	"fmt"
	yaml "gopkg.in/yaml.v2"
	"k8s.io/apimachinery/pkg/api/resource"
	"io/ioutil"
)

// Copied [important part only] from kubevirt - this can't be unmarshalled for some reason
type ResourceName string
type ResourceList map[ResourceName]resource.Quantity
type ResourceRequirements struct {
        Resources ResourceList `yaml:"resources"`
}

// type Quantity replaced with int
type IntResourceList map[ResourceName]int
type IntResourceRequirements struct {
        Resources IntResourceList `yaml:"resources"`
}

// How I did it
type MyResources struct {
	Resources   map[string]string `yaml:"resources"`
} 

func main() {
	byteYAML, _ := ioutil.ReadFile("structManifest.yml")
	fmt.Println("YAML:")
	fmt.Println(string(byteYAML))

	var data1 ResourceRequirements
	yaml.Unmarshal(byteYAML, &data1)
	fmt.Println("Kubevirt implementation with Quantity:")
	fmt.Println(data1)

	var data2 IntResourceRequirements
	yaml.Unmarshal(byteYAML, &data2)
	fmt.Println("Kubewirt implementation with int:")
	fmt.Println(data2)

	var data3 MyResources
	yaml.Unmarshal(byteYAML, &data3)
	fmt.Println("My implementation:")
	fmt.Println(data3)
}



package main

import (
	"fmt"
	"io/ioutil"
	"os"
)

func main() {
	// Đọc giá trị từ ConfigMap
	configKey := os.Getenv("CONFIG_KEY")
	fmt.Println("Config Key:", configKey)

	// Đọc giá trị từ Secret
	username, err := ioutil.ReadFile("/etc/secrets/username")
	if err != nil {
		panic(err)
	}
	password, err := ioutil.ReadFile("/etc/secrets/password")
	if err != nil {
		panic(err)
	}
	fmt.Printf("Username: %s, Password: %s\n", username, password)
}

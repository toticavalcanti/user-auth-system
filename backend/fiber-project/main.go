package main

import (
	"fiber-project/database"
	"fiber-project/routes"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
)

func main() {
	database.Connect()
	app := fiber.New()

	app.Use(cors.New(cors.Config{
		AllowOrigins:     "http://206.189.253.145", // IP do frontend
		AllowCredentials: true,
		AllowMethods:     "GET,POST,PUT,DELETE",
	}))

	routes.Setup(app)
	app.Listen(":3000")
}

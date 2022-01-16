package config

import (
	"os"
	"strconv"
)

type Config struct {
	Port               int    // port for this service to listen on
	HostPort           int    // web-host to reach this server on
	WebHost            string // port to display in the URL.This might be different then 'port' when running in a container, using Gin, ...
	VarsFile           string // file to write the variables to
	DefaultProjectName string // default name for the GCP project
}

func New() *Config {
	return &Config{

		Port:               getEnvAsInt("PORT", 8080),
		HostPort:           getEnvAsInt("HOST_PORT", 0),
		WebHost:            getEnvAsString("WEB_HOST", ""),
		VarsFile:           getEnvAsString("VARS_FILE", ""),
		DefaultProjectName: getEnvAsString("DEFAULT_PROJECT_NAME", ""),
	}
}

// Simple helper function to read an environment or return a default value.
func getEnvAsString(key, defaultVal string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}

	return defaultVal
}

// Simple helper function to read an environment variable into integer or return a default value.
func getEnvAsInt(key string, defaultVal int) int {
	valueStr := getEnvAsString(key, "")
	if value, err := strconv.Atoi(valueStr); err == nil {
		return value
	}

	return defaultVal
}

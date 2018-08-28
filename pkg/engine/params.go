package engine

import (
	"github.com/Microsoft/oe-engine/pkg/api"
)

func getParameters(cs *api.OpenEnclave, generatorCode string) (paramsMap, error) {
	//properties := cs.Properties
	location := cs.Location
	parametersMap := paramsMap{}

	// Common Parameters
	addValue(parametersMap, "location", location)

	return parametersMap, nil
}

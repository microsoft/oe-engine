package engine

import (
	"fmt"
	"path"

	"github.com/Microsoft/oe-engine/pkg/api"
)

// ArtifactWriter represents the object that writes artifacts
type ArtifactWriter struct {
}

// WriteTLSArtifacts saves TLS certificates and keys to the server filesystem
func (w *ArtifactWriter) WriteTLSArtifacts(oe *api.OpenEnclave, template, parameters, artifactsDir string, certsGenerated bool, parametersOnly bool) error {
	if len(artifactsDir) == 0 {
		artifactsDir = fmt.Sprintf("%s-%s", "oe", "00") //GenerateClusterID(oe.Properties))
		artifactsDir = path.Join("_output", artifactsDir)
	}

	f := &FileSaver{}

	// convert back the API object, and write it
	var b []byte
	var err error
	if !parametersOnly {
		apiloader := &api.Apiloader{}
		b, err = apiloader.SerializeOpenEnclave(oe)

		if err != nil {
			return err
		}

		if e := f.SaveFile(artifactsDir, "apimodel.json", b); e != nil {
			return e
		}

		if e := f.SaveFileString(artifactsDir, "azuredeploy.json", template); e != nil {
			return e
		}
	}

	if e := f.SaveFileString(artifactsDir, "azuredeploy.parameters.json", parameters); e != nil {
		return e
	}

	if !certsGenerated {
		return nil
	}
	return nil
}

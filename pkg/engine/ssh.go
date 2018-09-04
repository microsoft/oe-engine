package engine

import (
	"crypto/rand"
	"crypto/rsa"
	"fmt"

	"github.com/Microsoft/oe-engine/pkg/helpers"
)

// CreateSaveSSH generates and stashes an SSH key pair.
func CreateSaveSSH(username, outputDirectory string) (privateKey *rsa.PrivateKey, publicKeyString string, err error) {

	privateKey, publicKeyString, err = helpers.CreateSSH(rand.Reader)
	if err != nil {
		return nil, "", err
	}

	privateKeyPem := privateKeyToPem(privateKey)

	f := &FileSaver{}

	err = f.SaveFile(outputDirectory, fmt.Sprintf("%s_rsa", username), privateKeyPem)
	if err != nil {
		return nil, "", err
	}

	return privateKey, publicKeyString, nil
}

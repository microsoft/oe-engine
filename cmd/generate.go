package cmd

import (
	"errors"
	"fmt"
	"io/ioutil"
	"os"
	"strings"

	"github.com/Microsoft/oe-engine/pkg/api"
	"github.com/Microsoft/oe-engine/pkg/engine"
	"github.com/Microsoft/oe-engine/pkg/engine/transform"
	log "github.com/sirupsen/logrus"
	"github.com/spf13/cobra"
)

const (
	generateName             = "generate"
	generateShortDescription = "Generate an Azure Resource Manager template"
	generateLongDescription  = "Generates an Azure Resource Manager template and parameters file"
)

type generateCmd struct {
	apimodelPath    string
	outputDirectory string
	sshPubKeys      []string
	noPrettyPrint   bool
	parametersOnly  bool

	// derived
	oe *api.OpenEnclave
}

func newGenerateCmd() *cobra.Command {
	gc := generateCmd{}

	generateCmd := &cobra.Command{
		Use:   generateName,
		Short: generateShortDescription,
		Long:  generateLongDescription,
		RunE: func(cmd *cobra.Command, args []string) error {
			if err := gc.validate(cmd, args); err != nil {
				log.Fatalf(fmt.Sprintf("error validating generateCmd: %s", err.Error()))
			}

			if err := gc.loadAPIModel(cmd, args); err != nil {
				log.Fatalf(fmt.Sprintf("error loading API model in generateCmd: %s", err.Error()))
			}

			return gc.run()
		},
	}

	f := generateCmd.Flags()
	f.StringVar(&gc.apimodelPath, "api-model", "", "")
	f.StringVar(&gc.outputDirectory, "output-directory", "", "output directory (_output if absent)")
	f.StringArrayVar(&gc.sshPubKeys, "ssh-public-key", nil, "SSH public key file path")
	f.BoolVar(&gc.noPrettyPrint, "no-pretty-print", false, "skip pretty printing the output")
	f.BoolVar(&gc.parametersOnly, "parameters-only", false, "only output parameters files")

	return generateCmd
}

func (gc *generateCmd) validate(cmd *cobra.Command, args []string) error {

	if gc.apimodelPath == "" {
		if len(args) == 1 {
			gc.apimodelPath = args[0]
		} else if len(args) > 1 {
			cmd.Usage()
			return errors.New("too many arguments were provided to 'generate'")
		} else {
			cmd.Usage()
			return errors.New("--api-model was not supplied, nor was one specified as a positional argument")
		}
	}

	if _, err := os.Stat(gc.apimodelPath); os.IsNotExist(err) {
		return fmt.Errorf(fmt.Sprintf("specified api model does not exist (%s)", gc.apimodelPath))
	}

	for i, keyPath := range gc.sshPubKeys {
		if _, err := os.Stat(keyPath); os.IsNotExist(err) {
			return fmt.Errorf(fmt.Sprintf("ssh public key file %s does not exist", keyPath))
		}
		b, err := ioutil.ReadFile(keyPath)
		if err != nil {
			return err
		}
		gc.sshPubKeys[i] = strings.TrimSpace(string(b))
	}

	return nil
}

func (gc *generateCmd) loadAPIModel(cmd *cobra.Command, args []string) error {
	var err error

	apiloader := &api.Apiloader{}
	gc.oe, err = apiloader.LoadOpenEnclaveFromFile(gc.apimodelPath, true, false, gc.sshPubKeys)
	if err != nil {
		return fmt.Errorf(fmt.Sprintf("error parsing the api model: %s", err.Error()))
	}

	if gc.outputDirectory == "" {
		gc.outputDirectory = "_output"
	}
	return nil
}

func (gc *generateCmd) run() error {
	log.Infoln(fmt.Sprintf("Generating assets into %s...", gc.outputDirectory))

	templateGenerator, err := engine.InitializeTemplateGenerator()
	if err != nil {
		log.Fatalf("failed to initialize template generator: %s", err.Error())
	}

	template, parameters, certsGenerated, err := templateGenerator.GenerateTemplate(gc.oe, api.DefaultGeneratorCode, false)
	if err != nil {
		log.Fatalf("error generating template %s: %s", gc.apimodelPath, err.Error())
		os.Exit(1)
	}

	if !gc.noPrettyPrint {
		if template, err = transform.PrettyPrintArmTemplate(template); err != nil {
			log.Fatalf("error pretty printing template: %s \n", err.Error())
		}
		if parameters, err = transform.BuildAzureParametersFile(parameters); err != nil {
			log.Fatalf("error pretty printing template parameters: %s \n", err.Error())
		}
	}

	writer := &engine.ArtifactWriter{}
	if err = writer.WriteTLSArtifacts(gc.oe, template, parameters, gc.outputDirectory, certsGenerated, gc.parametersOnly); err != nil {
		log.Fatalf("error writing artifacts: %s \n", err.Error())
	}

	return nil
}

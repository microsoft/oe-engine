package engine

import (
	"testing"

	"github.com/Microsoft/oe-engine/pkg/api"
)

func TestStorageProfile(t *testing.T) {
	// Test ManagedDisks default configuration
	mockCS := getMockBaseContainerService("1.8.10")
	properties := mockCS.Properties
	properties.OrchestratorProfile.OrchestratorType = "DCOS"
	properties.MasterProfile.Count = 1

	setPropertiesDefaults(&mockCS, false)
	if properties.MasterProfile.StorageProfile != api.ManagedDisks {
		t.Fatalf("MasterProfile.StorageProfile did not have the expected configuration, got %s, expected %s",
			properties.MasterProfile.StorageProfile, api.ManagedDisks)
	}
	if !properties.MasterProfile.IsManagedDisks() {
		t.Fatalf("MasterProfile.StorageProfile did not have the expected configuration, got %t, expected %t",
			false, true)
	}
	if properties.AgentPoolProfiles[0].StorageProfile != api.StorageAccount {
		t.Fatalf("AgentPoolProfile.StorageProfile did not have the expected configuration, got %s, expected %s",
			properties.AgentPoolProfiles[0].StorageProfile, api.ManagedDisks)
	}
	if !properties.AgentPoolProfiles[0].IsStorageAccount() {
		t.Fatalf("AgentPoolProfile.IsStorageAccount() did not have the expected configuration, got %t, expected %t",
			false, true)
	}
	if !properties.AgentPoolProfiles[0].IsVirtualMachineScaleSets() {
		t.Fatalf("AgentPoolProfile[0].IsVirtualMachineScaleSets did not have the expected configuration, got %s, expected %s",
			properties.AgentPoolProfiles[0].AvailabilityProfile, api.AvailabilitySet)
	}

	mockCS = getMockBaseContainerService("1.10.0")
	properties = mockCS.Properties
	properties.OrchestratorProfile.OrchestratorType = "DCOS"
	setPropertiesDefaults(&mockCS, false)
	if !properties.AgentPoolProfiles[0].IsVirtualMachineScaleSets() {
		t.Fatalf("AgentPoolProfile[0].AvailabilityProfile did not have the expected configuration, got %s, expected %s",
			properties.AgentPoolProfiles[0].AvailabilityProfile, api.VirtualMachineScaleSets)
	}

}

func TestAgentPoolProfile(t *testing.T) {
	mockCS := getMockBaseContainerService("1.10")
	properties := mockCS.Properties
	properties.OrchestratorProfile.OrchestratorType = "DCOS"
	properties.MasterProfile.Count = 1
	setPropertiesDefaults(&mockCS, false)
	if properties.AgentPoolProfiles[0].ScaleSetPriority != "" {
		t.Fatalf("AgentPoolProfiles[0].ScaleSetPriority did not have the expected configuration, got %s, expected %s",
			properties.AgentPoolProfiles[0].ScaleSetPriority, "")
	}
	if properties.AgentPoolProfiles[0].ScaleSetEvictionPolicy != "" {
		t.Fatalf("AgentPoolProfiles[0].ScaleSetEvictionPolicy did not have the expected configuration, got %s, expected %s",
			properties.AgentPoolProfiles[0].ScaleSetEvictionPolicy, "")
	}
	properties.AgentPoolProfiles[0].ScaleSetPriority = api.ScaleSetPriorityLow
	setPropertiesDefaults(&mockCS, false)
	if properties.AgentPoolProfiles[0].ScaleSetEvictionPolicy != api.ScaleSetEvictionPolicyDelete {
		t.Fatalf("AgentPoolProfile[0].ScaleSetEvictionPolicy did not have the expected configuration, got %s, expected %s",
			properties.AgentPoolProfiles[0].ScaleSetEvictionPolicy, api.ScaleSetEvictionPolicyDelete)
	}
}

func getMockBaseContainerService(orchestratorVersion string) api.ContainerService {
	return api.ContainerService{
		Properties: &api.Properties{
			OrchestratorProfile: &api.OrchestratorProfile{
				OrchestratorVersion: orchestratorVersion,
			},
			MasterProfile: &api.MasterProfile{},
			AgentPoolProfiles: []*api.AgentPoolProfile{
				{},
			},
		},
	}
}

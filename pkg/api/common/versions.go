package common

import (
	"fmt"

	"github.com/blang/semver"
)

// GetVersionsGt returns a list of versions greater than a semver string given a list of versions
// inclusive=true means that we test for equality as well
// preReleases=true means that we include pre-release versions in the list
func GetVersionsGt(versions []string, version string, inclusive, preReleases bool) []string {
	// Try to get latest version matching the release
	var ret []string
	minVersion, _ := semver.Make(version)
	for _, v := range versions {
		sv, _ := semver.Make(v)
		if !preReleases && len(sv.Pre) != 0 {
			continue
		}
		if (inclusive && sv.GTE(minVersion)) || (!inclusive && sv.GT(minVersion)) {
			ret = append(ret, v)
		}
	}
	return ret
}

// GetVersionsLt returns a list of versions less than than a semver string given a list of versions
// inclusive=true means that we test for equality as well
// preReleases=true means that we include pre-release versions in the list
func GetVersionsLt(versions []string, version string, inclusive, preReleases bool) []string {
	// Try to get latest version matching the release
	var ret []string
	minVersion, _ := semver.Make(version)
	for _, v := range versions {
		sv, _ := semver.Make(v)
		if !preReleases && len(sv.Pre) != 0 {
			continue
		}
		if (inclusive && sv.LTE(minVersion)) || (!inclusive && sv.LT(minVersion)) {
			ret = append(ret, v)
		}
	}
	return ret
}

// GetVersionsBetween returns a list of versions between a min and max
// inclusive=true means that we test for equality on both bounds
// preReleases=true means that we include pre-release versions in the list
func GetVersionsBetween(versions []string, versionMin, versionMax string, inclusive, preReleases bool) []string {
	var ret []string
	if minV, _ := semver.Make(versionMin); len(minV.Pre) != 0 {
		preReleases = true
	}
	greaterThan := GetVersionsGt(versions, versionMin, inclusive, preReleases)
	lessThan := GetVersionsLt(versions, versionMax, inclusive, preReleases)
	for _, lv := range lessThan {
		for _, gv := range greaterThan {
			if lv == gv {
				ret = append(ret, lv)
			}
		}
	}
	return ret
}

// GetMaxVersion gets the highest semver version
// preRelease=true means accept a pre-release version as a max value
func GetMaxVersion(versions []string, preRelease bool) string {
	if len(versions) < 1 {
		return ""
	}
	highest, _ := semver.Make("0.0.0")
	highestPreRelease, _ := semver.Make("0.0.0-alpha.0")
	var preReleaseVersions []semver.Version
	for _, v := range versions {
		sv, _ := semver.Make(v)
		if len(sv.Pre) != 0 {
			preReleaseVersions = append(preReleaseVersions, sv)
		} else {
			if sv.Compare(highest) == 1 {
				highest = sv
			}
		}
	}
	if preRelease {
		for _, sv := range preReleaseVersions {
			if sv.Compare(highestPreRelease) == 1 {
				highestPreRelease = sv
			}
		}
		switch highestPreRelease.Compare(highest) {
		case 1:
			return highestPreRelease.String()
		default:
			return highest.String()
		}

	}
	return highest.String()
}

// GetLatestPatchVersion gets the most recent patch version from a list of semver versions given a major.minor string
func GetLatestPatchVersion(majorMinor string, versionsList []string) (version string) {
	// Try to get latest version matching the release
	version = ""
	for _, ver := range versionsList {
		sv, err := semver.Make(ver)
		if err != nil {
			return
		}
		sr := fmt.Sprintf("%d.%d", sv.Major, sv.Minor)
		if sr == majorMinor {
			if version == "" {
				version = ver
			} else {
				current, _ := semver.Make(version)
				if sv.GT(current) {
					version = ver
				}
			}
		}
	}
	return version
}

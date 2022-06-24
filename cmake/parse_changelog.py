import argparse
import re

HEADER_RE = re.compile('##\s+\[(?P<major>\d+)\.(?P<minor>\d+)\.(?P<build>\d+)\].*?')


class Version(object):
    def __init__(self, major, minor, build) -> None:
        self.major = major 
        self.minor = minor
        self.build = build


class ChangeLog(object):
    def __init__(self, versions) -> None:
        self.versions = versions

    @classmethod
    def parse(cls, data: str) -> 'ChangeLog':
        lines = [x.strip() for x in data.split('\n')]
        versions = []
        for line in lines:
            if not line.startswith('##'):
                continue
            m = HEADER_RE.match(line)
            if m is None:
                continue
            major = int(m.group('major'))
            minor = int(m.group('minor'))
            build = int(m.group('build'))
            versions.append(Version(major, minor, build))
        return ChangeLog(versions)


HEADER_TEMPLATE = '''
#ifndef CONFIG_VERSION_H
#define CONFIG_VERSION_H

#define VERSION_MAJOR       {major}
#define VERSION_MINOR       {minor}
#define VERSION_BUILD       {build}

#endif // CONFIG_VERSION_H
'''


def main():
    parser = argparse.ArgumentParser(description='Dump version number into header file.')
    parser.add_argument('changelog_file', help='The file path of the changelog')
    parser.add_argument('output_file', help='The file path where the header file should be written to')
    args = parser.parse_args()
    fpath = args.changelog_file

    with open(fpath, 'r') as f:
        changelog = f.read()
    changelog = ChangeLog.parse(changelog)

    latest = changelog.versions[0]
    result = HEADER_TEMPLATE.format(major=latest.major, minor=latest.minor, build=latest.build)

    output_path = args.output_file
    with open(output_path, 'w') as f:
        f.write(result)


if __name__ == '__main__':
    main()

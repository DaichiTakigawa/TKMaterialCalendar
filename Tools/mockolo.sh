#/bin/sh

if which mockolo > /dev/null; then
  rm -f ../Generated/MockResults.swift
  mockolo --sourcedirs ../TKMaterialCalendar --destination ../Generated/MockResults.swift  --mock-all
else
  echo "warning: mockolo not installed, download from https://github.com/uber/mockolo"
fi

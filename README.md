# Stitch

Merge two CSV files together on a matching field to a new combined CSV file in the same directory.

## Installation and usage

```
$ git clone https://github.com/mkreyman/stitch.git

$ cd stitch

$ mix deps.get

$ mix escript.build

$ ./stitch test/fixtures/file1.csv test/fixtures/file2.csv name
# =>  Output CSV file:
# =>    <path_to>/test/fixtures/matched_file1.csv
```

Enjoy! :)



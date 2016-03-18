# Problems with NFIRS data files
* **causes.txt**: Header (^) and lines (,) have mismatched delimiters. 
Fixed with sed.
```
sed 's/,/^g' causes.txt > causes-fixed.txt
```
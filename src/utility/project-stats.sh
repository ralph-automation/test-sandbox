#!/usr/bin/env bash

echo "=== Project Stats ==="

# Count files in each src/ subdirectory
for dir in src/*/; do
    if [ -d "$dir" ]; then
        count=$(find "$dir" -type f | wc -l)
        echo "src/${dir#src/}: $count files"
    fi
done

# Count files by extension
js_count=$(find . -name "*.js" -not -path "*/node_modules/*" -not -path "*/.git/*" | wc -l)
html_count=$(find . -name "*.html" -not -path "*/node_modules/*" -not -path "*/.git/*" | wc -l)
css_count=$(find . -name "*.css" -not -path "*/node_modules/*" -not -path "*/.git/*" | wc -l)
sh_count=$(find . -name "*.sh" -not -path "*/node_modules/*" -not -path "*/.git/*" | wc -l)
md_count=$(find . -name "*.md" -not -path "*/node_modules/*" -not -path "*/.git/*" | wc -l)

echo ".js files: $js_count"
echo ".html files: $html_count"
echo ".css files: $css_count"
echo ".sh files: $sh_count"
echo ".md files: $md_count"

# Total lines of code
total_lines=$(find . -type f -not -path "*/node_modules/*" -not -path "*/.git/*" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')
echo "Total lines of code: $total_lines"

exit 0

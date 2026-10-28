Set-Location $PSScriptRoot\..
$env:GIT_INDEX_FILE = (Join-Path $PWD '.git\tmp_index')
if (Test-Path $env:GIT_INDEX_FILE) { Remove-Item $env:GIT_INDEX_FILE }
git read-tree origin/main
$root = $PWD.Path
$files = Get-ChildItem $root -Recurse -File | Where-Object {
  $_.FullName -notmatch '\\(tools|\.git)\\' -and $_.Name -notin 'ABRIR_SITE.bat', '.nojekyll'
}
$rels = $files | ForEach-Object { $_.FullName.Substring($root.Length + 1) }
$hashes = $rels | git hash-object -w --stdin-paths
"arquivos: $($rels.Count) hashes: $(@($hashes).Count)"
for ($i = 0; $i -lt $rels.Count; $i++) {
  git update-index --add --cacheinfo "100644,$($hashes[$i]),catalogo/$($rels[$i] -replace '\\', '/')"
}
$tree = git write-tree
$commit = git commit-tree $tree -p origin/main -m "Adiciona catalogo completo em /catalogo"
git update-ref refs/heads/publicar $commit
Remove-Item $env:GIT_INDEX_FILE
"commit $commit"
git ls-tree -r --name-only publicar | Measure-Object | ForEach-Object Count
git ls-tree --name-only publicar

npx local-web-server \
  --https \
  --cors.embedder-policy "require-corp"\
  --cors.opener-policy "same-origin" \
  --directory ./build
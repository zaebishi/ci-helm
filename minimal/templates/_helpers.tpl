{{/* ===== parseLines: список строк без пустых/комментов, CRLF и BOM ===== */}}
{{- define "env.parseLines" -}}
{{- $raw := . | default "" -}}
{{- /* убираем CR и BOM в начале каждой строки */ -}}
{{- $noCR := regexReplaceAll "\r" $raw "" -}}
{{- $lines := splitList "\n" $noCR -}}
{{- $clean := list -}}
{{- range $lines }}
  {{- $line := regexReplaceAll "^\uFEFF" (trim .) "" -}}
  {{- if and $line (not (hasPrefix $line "#")) }}
    {{- $clean = append $clean $line -}}
  {{- end }}
{{- end }}
{{- toYaml $clean -}}
{{- end -}}

{{/* ===== splitKV: "KEY=VALUE" -> YAML-объект {key:..., val:...} ===== */}}
{{- define "env.splitKV" -}}
{{- $parts := regexSplit "=" . 2 -}}
{{- $k := trim (index $parts 0) -}}
{{- $v := "" -}}
{{- if gt (len $parts) 1 }}{{- $v = trim (index $parts 1) -}}{{- end -}}
{{- $v = (trimAll "'" (trimAll "\"" $v)) -}}
{{- toYaml (dict "key" $k "val" $v) -}}
{{- end -}}

{{- define "env.cmData" -}}
{{- $dotenv := .dotenv | default "" -}}
{{- $strip := .strip | default true -}}
{{- $lines := (include "env.parseLines" $dotenv) | fromYaml -}}
{{- $data := dict -}}
{{- range $lines }}
  {{- $pair := (include "env.splitKV" .) | fromYaml -}}
  {{- $k := trim $pair.key -}}
  {{- $v := $pair.val -}}
  {{- if regexMatch "^ENV__" $k }}
    {{- $name := ternary (regexReplaceAll "^ENV__" "" $k) $k $strip -}}
    {{- $_ := set $data $name $v -}}
  {{- end }}
{{- end }}
{{- toYaml $data -}}
{{- end -}}

{{- define "env.secretData" -}}
{{- $dotenv := .dotenv | default "" -}}
{{- $strip := .strip | default true -}}
{{- $lines := (include "env.parseLines" $dotenv) | fromYaml -}}
{{- $data := dict -}}
{{- range $lines }}
  {{- $pair := (include "env.splitKV" .) | fromYaml -}}
  {{- $k := trim $pair.key -}}
  {{- $v := $pair.val -}}
  {{- if regexMatch "^SECRET__" $k }}
    {{- $name := ternary (regexReplaceAll "^SECRET__" "" $k) $k $strip -}}
    {{- $_ := set $data $name $v -}}
  {{- end }}
{{- end }}
{{- toYaml $data -}}
{{- end -}}

{{/* ===== имена ресурсов ===== */}}
{{- define "env.cmName" -}}
{{- default (printf "%s-env" .Release.Name) .Values.envFrom.configMapName -}}
{{- end -}}
{{- define "env.secretName" -}}
{{- default (printf "%s-secret" .Release.Name) .Values.envFrom.secretName -}}
{{- end -}}

{{/* ===== checksum для рестарта подов при изменении файла ===== */}}
{{- define "env.dotenvChecksum" -}}
{{- sha256sum (default "" .Values.envFrom.dotenv) -}}
{{- end -}}
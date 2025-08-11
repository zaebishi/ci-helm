{{/*
  Split dotenv в список непустых строк без комментариев
*/}}
{{- define "env.parseLines" -}}
{{- $dotenv := . | default "" -}}
{{- $lines := splitList "\n" $dotenv -}}
{{- $clean := list -}}
{{- range $lines }}
  {{- $line := trim . -}}
  {{- if and $line (not (hasPrefix $line "#")) }}
    {{- $clean = append $clean $line -}}
  {{- end }}
{{- end }}
{{- return $clean -}}
{{- end -}}

{{/*
  Разбор пары key=value: берём всё правее первого "=" как value.
  Результат: dict "key" k "val" v
*/}}
{{- define "env.splitKV" -}}
{{- $line := . -}}
{{- $parts := regexSplit "=" $line 2 -}}
{{- $k := trim (index $parts 0) -}}
{{- $v := "" -}}
{{- if gt (len $parts) 1 }}{{- $v = trim (index $parts 1) -}}{{- end -}}
{{- $v = (trimAll "'" (trimAll "\"" $v)) -}}
{{- return (dict "key" $k "val" $v) -}}
{{- end -}}

{{/*
  Собрать ConfigMap data из dotenv.
  Аргументы (dict):
    dotenv: string
    strip: bool  (stripPrefixes)
*/}}
{{- define "env.cmData" -}}
{{- $dotenv := .dotenv | default "" -}}
{{- $strip := .strip | default true -}}
{{- $lines := include "env.parseLines" $dotenv | fromYamlArray -}}
{{- $data := dict -}}
{{- range $lines }}
  {{- $pair := (include "env.splitKV" . | fromYaml) -}}
  {{- $k := $pair.key -}}
  {{- $v := $pair.val -}}
  {{- if hasPrefix $k "ENV__" }}
    {{- $name := (cond $strip (regexReplaceAll "^ENV__" "" $k) $k) -}}
    {{- $_ := set $data $name $v -}}
  {{- end }}
{{- end }}
{{- return $data -}}
{{- end -}}

{{/*
  Собрать Secret data из dotenv (stringData).
  Аргументы (dict):
    dotenv: string
    strip: bool
*/}}
{{- define "env.secretData" -}}
{{- $dotenv := .dotenv | default "" -}}
{{- $strip := .strip | default true -}}
{{- $lines := include "env.parseLines" $dotenv | fromYamlArray -}}
{{- $data := dict -}}
{{- range $lines }}
  {{- $pair := (include "env.splitKV" . | fromYaml) -}}
  {{- $k := $pair.key -}}
  {{- $v := $pair.val -}}
  {{- if hasPrefix $k "SECRET__" }}
    {{- $name := (cond $strip (regexReplaceAll "^SECRET__" "" $k) $k) -}}
    {{- $_ := set $data $name $v -}}
  {{- end }}
{{- end }}
{{- return $data -}}
{{- end -}}

{{/*
  Имена ресурсов
*/}}
{{- define "env.cmName" -}}
{{- $ := . -}}
{{- default (printf "%s-env" $.Release.Name) $.Values.envFrom.configMapName -}}
{{- end -}}
{{- define "env.secretName" -}}
{{- $ := . -}}
{{- default (printf "%s-secret" $.Release.Name) $.Values.envFrom.secretName -}}
{{- end -}}

{{/*
  Чексуммируем сырой dotenv, чтобы триггерить rollout
*/}}
{{- define "env.dotenvChecksum" -}}
{{- sha256sum (default "" .Values.envFrom.dotenv) -}}
{{- end -}}
{{- define "nestjs-chart.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "nestjs-chart.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end }}

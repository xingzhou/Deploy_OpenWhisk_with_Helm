{ Get redis service name */}}
{{- define "redis_service_name" -}}
{{ .Values.serviceName | default "redis" | quote }}
{{- end -}}

{ Get redis deployment name */}}
{{- define "redis_deployment_name" -}}
{{ .Values.deploymentName | default "redis" | quote }}
{{- end -}}

{{/* Set port */}}
{{- define "redis_port" -}}
{{ .Values.port | default 6379 }}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "guardian-ipfs-client.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "guardian-ipfs-client.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "guardian-ipfs-client.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "guardian-ipfs-client.labels" -}}
helm.sh/chart: {{ include "guardian-ipfs-client.chart" . }}
{{ include "guardian-ipfs-client.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "guardian-ipfs-client.selectorLabels" -}}
app.kubernetes.io/name: {{ include "guardian-ipfs-client.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
aws-schedule: fargate
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "guardian-ipfs-client.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "guardian-ipfs-client.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

view: stdout {
  sql_table_name: `onlineboutique_default_namespace.stdout`
    ;;

  dimension: http_request {
    hidden: yes
    sql: ${TABLE}.httpRequest ;;
  }

  dimension: insert_id {
    type: string
    sql: ${TABLE}.insertId ;;
  }

  dimension: json_payload {
    hidden: yes
    sql: ${TABLE}.jsonPayload ;;
  }

  dimension: labels {
    hidden: yes
    sql: ${TABLE}.labels ;;
  }

  dimension: log_name {
    type: string
    sql: ${TABLE}.logName ;;
  }

  dimension: operation {
    hidden: yes
    sql: ${TABLE}.operation ;;
  }

  dimension_group: receive_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.receiveTimestamp ;;
  }

  dimension: resource {
    hidden: yes
    sql: ${TABLE}.resource ;;
  }

  dimension: severity {
    type: string
    sql: ${TABLE}.severity ;;
  }

  dimension: source_location {
    hidden: yes
    sql: ${TABLE}.sourceLocation ;;
  }

  dimension: span_id {
    type: string
    sql: ${TABLE}.spanId ;;
  }

  dimension: text_payload {
    type: string
    sql: ${TABLE}.textPayload ;;
  }

  dimension_group: timestamp {
    type: time
    timeframes: [
      raw,
      time,
      millisecond,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.timestamp ;;
  }

  parameter: selected_timestamp  {
    type: string
    suggest_dimension: timestamp_raw
  }

  dimension: is_selected_timestamp {
    type: string
    sql:
    CASE
    WHEN ${timestamp_millisecond} = {% parameter selected_timestamp %}
    THEN 'Selected'
    ELSE 'All Others'
    END
    ;;
  }

  dimension: trace {
    type: string
    sql: ${TABLE}.trace ;;
  }

  dimension: trace_sampled {
    type: yesno
    sql: ${TABLE}.traceSampled ;;
  }

  measure: count {
    type: count
    drill_fields: [timestamp_time, http_request, resource, trace ]
  }

  measure: error_count {
    type: count
    filters: [stdout__json_payload.is_error: "Yes"]
  }



}

view: stdout__resource {
  dimension: labels {
    hidden: yes
    sql: ${TABLE}.labels ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}.type ;;
  }
}

view: stdout__resource__labels {
  dimension: cluster_name {
    type: string
    sql: ${TABLE}.cluster_name ;;
  }

  dimension: container_name {
    type: string
    sql: ${TABLE}.container_name ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}.location ;;
  }

  dimension: namespace_name {
    type: string
    sql: ${TABLE}.namespace_name ;;
  }

  dimension: pod_name {
    type: string
    sql: ${TABLE}.pod_name ;;
  }

  dimension: project_id {
    type: string
    sql: ${TABLE}.project_id ;;
  }
}

view: stdout__labels {
  dimension: k8s_pod_app {
    type: string
    sql: ${TABLE}.k8s_pod_app ;;
  }

  dimension: k8s_pod_istio_io_rev {
    type: string
    sql: ${TABLE}.k8s_pod_istio_io_rev ;;
  }

  dimension: k8s_pod_pod_template_hash {
    type: string
    sql: ${TABLE}.k8s_pod_pod_template_hash ;;
  }

  dimension: k8s_pod_security_istio_io_tlsmode {
    type: string
    sql: ${TABLE}.k8s_pod_security_istio_io_tlsmode ;;
  }

  dimension: k8s_pod_service_istio_io_canonical_name {
    type: string
    sql: ${TABLE}.k8s_pod_service_istio_io_canonical_name ;;
  }

  dimension: k8s_pod_service_istio_io_canonical_revision {
    type: string
    sql: ${TABLE}.k8s_pod_service_istio_io_canonical_revision ;;
  }
}

view: stdout__json_payload {
  dimension: currency {
    type: string
    sql: ${TABLE}.currency ;;
  }

  dimension: hostname {
    type: string
    sql: ${TABLE}.hostname ;;
  }

  dimension: http_req_id {
    label: "HTTP Request ID"
    type: string
    sql: ${TABLE}.http_req_id ;;
  }

  dimension: http_req_method {
    label: "HTTP Request Method"
    type: string
    sql: ${TABLE}.http_req_method ;;
  }

  dimension: http_req_path {
    label: "HTTP Request Path (full)"
    type: string
    sql: ${TABLE}.http_req_path ;;
  }

  dimension: api {
    label: "HTTP Request Path"
    sql: REGEXP_EXTRACT(${http_req_path}, r"^\/([a-zA-Z]+)\/") ;;
  }

  dimension: http_resp_bytes {
    label: "HTTP Response Bytes"
    type: number
    sql: ${TABLE}.http_resp_bytes ;;
  }

  dimension: http_resp_status {
    label: "HTTP Response Status"
    type: number
    sql: ${TABLE}.http_resp_status ;;
  }

  dimension: is_error {
    type: yesno
    sql: ${http_resp_status} >= 400 ;;
  }

##### HTTP Response Time #####################################

  dimension: http_resp_took_ms {
    label: "HTTP Response Time (ms)"
    description: "HTTP response time in Milliseconds"
    type: number
    sql: ${TABLE}.http_resp_took_ms ;;
  }

  parameter: http_resp_latency_slo {
    type: number
    suggest_dimension: http_resp_took_ms
  }

  dimension: http_resp_exceeds_slo_target {
    label: "HTTP Response Exceeds SLO Target"
    type: yesno
    sql: ${http_resp_took_ms} >= {% parameter http_resp_latency_slo %} ;;
  }

  dimension: http_resp_took_sec {
    label: "HTTP Response Time (seconds)"
    description: "HTTP response time in Seconds"
    type: number
    sql: ${http_resp_took_ms} / 1000 ;;
  }

  measure:  max_http_response_time {
    label: "HTTP Response (Max)"
    type:  max
    sql: ${http_resp_took_ms} ;;
    link: {
      label: "Lookup Dashboard"
      url: "/dashboards-next/932?Selected+Timestamp={{ stdout.timestamp_millisecond._value }}"
    }
  }

  measure:  avg_http_response_time {
    label: "HTTP Response (Avg)"
    type:  average
    value_format_name: decimal_0
    sql: ${http_resp_took_ms} ;;
  }

  dimension: logevent {
    type: string
    sql: ${TABLE}.logevent ;;
  }

  dimension: logging_googleapis_com_tracesampled {
    type: string
    sql: ${TABLE}.logging_googleapis_com_tracesampled ;;
  }

  dimension: message {
    type: string
    sql: ${TABLE}.message ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: pid {
    type: number
    value_format_name: id
    sql: ${TABLE}.pid ;;
  }

  dimension: session {
    type: string
    sql: ${TABLE}.session ;;
  }

  dimension: timestamp {
    type: string
    sql: ${TABLE}.timestamp ;;
  }

  dimension: v {
    type: number
    sql: ${TABLE}.v ;;
  }

  set: common_drill_fields {
    fields: [timestamp, http_req_method, api, http_resp_status, http_resp_took_ms]
  }

  drill_fields: [common_drill_fields*]
}

view: stdout__http_request {
  dimension: cache_fill_bytes {
    type: number
    sql: ${TABLE}.cacheFillBytes ;;
  }

  dimension: cache_hit {
    type: yesno
    sql: ${TABLE}.cacheHit ;;
  }

  dimension: cache_lookup {
    type: yesno
    sql: ${TABLE}.cacheLookup ;;
  }

  dimension: cache_validated_with_origin_server {
    type: yesno
    sql: ${TABLE}.cacheValidatedWithOriginServer ;;
  }

  dimension: protocol {
    type: string
    sql: ${TABLE}.protocol ;;
  }

  dimension: referer {
    type: string
    sql: ${TABLE}.referer ;;
  }

  dimension: remote_ip {
    type: string
    sql: ${TABLE}.remoteIp ;;
  }

  dimension: request_method {
    type: string
    sql: ${TABLE}.requestMethod ;;
  }

  dimension: request_size {
    type: number
    sql: ${TABLE}.requestSize ;;
  }

  dimension: request_url {
    type: string
    sql: ${TABLE}.requestUrl ;;
  }

  dimension: response_size {
    type: number
    sql: ${TABLE}.responseSize ;;
  }

  dimension: server_ip {
    type: string
    sql: ${TABLE}.serverIp ;;
  }

  dimension: status {
    type: number
    sql: ${TABLE}.status ;;
  }

  dimension: user_agent {
    type: string
    sql: ${TABLE}.userAgent ;;
  }
}

view: stdout__source_location {
  dimension: file {
    type: string
    sql: ${TABLE}.file ;;
  }

  dimension: function {
    type: string
    sql: ${TABLE}.function ;;
  }

  dimension: line {
    type: number
    sql: ${TABLE}.line ;;
  }
}

view: stdout__operation {
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: first {
    type: yesno
    sql: ${TABLE}.first ;;
  }

  dimension: last {
    type: yesno
    sql: ${TABLE}.last ;;
  }

  dimension: producer {
    type: string
    sql: ${TABLE}.producer ;;
  }
}

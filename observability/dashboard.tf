resource "aws_cloudwatch_dashboard" "checkout_service" { 

  dashboard_name = "DevSecOps-Checkout-Service" 

  

  dashboard_body = jsonencode({ 

    widgets = [ 

      { 

        type   = "metric" 

        x      = 0 

        y      = 0 

        width  = 12 

        height = 6 

        properties = { 

          title   = "Solicitudes vs Errores" 

          view    = "timeSeries" 

          region  = "us-east-1" 

          metrics = [ 

            ["DevSecOpsLab/CheckoutService", "RequestCount", { stat = "Sum", label = "Solicitudes" }], 

            ["DevSecOpsLab/CheckoutService", "ErrorCount", { stat = "Sum", label = "Errores" }] 

          ] 

        } 

      }, 

      { 

        type   = "metric" 

        x      = 12 

        y      = 0 

        width  = 12 

        height = 6 

        properties = { 

          title  = "Latencia (ms)" 

          view   = "timeSeries" 

          region = "us-east-1" 

          metrics = [ 

            ["DevSecOpsLab/CheckoutService", "LatencyMs", { stat = "Average", label = "Latencia promedio" }] 

          ] 

        } 

      }, 

      { 

        type   = "log" 

        x      = 0 

        y      = 6 

        width  = 24 

        height = 6 

        properties = { 

          title  = "Logs recientes del servicio de checkout" 

          region = "us-east-1" 

          query  = "SOURCE '/devsecops-lab/checkout-service' | fields @timestamp, @message | sort @timestamp desc | limit 20" 

        } 

      } 

    ] 

  }) 

} 
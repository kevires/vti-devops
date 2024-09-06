# Sử dụng Golang image để build
FROM golang:1.22.2 AS builder
WORKDIR /app
COPY . .
# Build ứng dụng
RUN go build -o main .
# Tạo Docker image cuối cùng
FROM alpine:latest
WORKDIR /root/
# Copy binary từ builder stage
COPY --from=builder /app/main .
CMD ["./main"]

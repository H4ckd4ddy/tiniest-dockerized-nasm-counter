FROM alpine
RUN apk add nasm
ADD count.asm /
RUN nasm -f bin -o count count.asm
RUN chmod +x count

FROM scratch
COPY --from=0 /count /
ENTRYPOINT ["/count"]
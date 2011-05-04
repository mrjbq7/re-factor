USING: tools.deploy.config ;
H{
    { deploy-name "calc-ui" }
    { deploy-ui? t }
    { deploy-c-types? f }
    { deploy-console? t }
    { deploy-unicode? f }
    { "stop-after-last-window?" t }
    { deploy-io 2 }
    { deploy-reflection 1 }
    { deploy-word-props? f }
    { deploy-math? t }
    { deploy-threads? t }
    { deploy-word-defs? f }
}

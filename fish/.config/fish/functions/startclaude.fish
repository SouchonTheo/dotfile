function startclaude
    if not test -d .devcontainer
        devc .; or return
    end
    sudo /home/theo/Code/ai-security/sandboxed-claude-code/firewall/iptables-apply-sandbox.sh; or return
    devc up; or return
    devc shell
end

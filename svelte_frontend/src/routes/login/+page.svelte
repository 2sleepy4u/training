<script>
    import { goto } from "$app/navigation";

    async function Login() {
        const path = "/get_new_session"
        try {
            //request SSID
            await fetch(path, {method: "POST"})
            //refresh page, if SSID is valid then it will redirect to daily list
            goto("/")
        } catch(e) { }

    }
</script>

<div>
    <input placeholder="email" type="email">
    <input placeholder="password" type="password">
    <button on:click={Login}>Log In</button>
</div>

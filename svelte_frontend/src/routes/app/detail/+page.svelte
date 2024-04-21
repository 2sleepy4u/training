<script>
	import { goto } from '$app/navigation';
    import { page } from '$app/stores';
    import ExerciseDetail from '$lib/ExerciseDetail.svelte';
</script>

{#if $page.state && Object.keys($page.state).length > 0}
    <ExerciseDetail 
        name = {$page.state.name}
        sets = {$page.state.sets}
        reps = {$page.state.reps}
        isDone = {$page.state.is_done}
        description = {$page.state.description}
    />
{:else }
    {goto("/app/list")}
{/if}

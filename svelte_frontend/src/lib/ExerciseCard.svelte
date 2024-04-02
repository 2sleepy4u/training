<script>
    export const ExerciseCard = this
    export let name = "Exercise Name"
    export let description = "Description.."
    export let isDone = false
</script>

<div 
    id = "exerciseCard" 
    on:click
    class = {isDone ? "done" : ""}
>
    {name}
    <br>
    {description}
</div>

<style>
    #exerciseCard {
        border: 1px solid black;
        border-radius: 15px;

        height: 50px;

        padding: 10px;
        margin: 10px;

        text-align: center;
    }

    .done {
        background-color: green;
    }
</style>

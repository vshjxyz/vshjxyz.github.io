---
layout: post
title: "Pure CSS3 turnover effect animation of a button without sprites"
date: 2013-09-01 15:06
comments: true
categories: [web design,frontend]
keywords: design,css3,compass,scss,sass,button,animation,transition,turnover,effect,hover
description: How to have a turnover effect on hover of a button
---
Ye ye I know that this is all but 'real' coding, but I want to grab the chance to post something here just because I've done some little css modifications to this blog.

Oh yes, I'm excited in particular about the 'read on' button animation and how easy is to achieve this without using sprites or images.

In short, here is where I want to go:

[{% imgcap center /images/pure-css3-turnover-effect-animation-of-a-button-without-sprites/animation.gif 400 67 The CSS3 button animation effect - click to zoom %}](/images/pure-css3-turnover-effect-animation-of-a-button-without-sprites/animation.gif)

<!--more-->

So, let's see the html code of the button:
{% codeblock lang:html %}
<!-- inside the article... -->
<footer>
    <div class="full-article">
            Read on →
            <a class="full-article-hover" rel="full-article" href="/yourlink">
                Read on →
            </a>
    </div>
</footer>
{% endcodeblock %}

As you can see, there's no real magic but a simple anchor (or link, whatever) `a` inside a `div` all wrapped in a `footer` element.

The `footer` will be our viewport, the `div` will be the only element animated and it should translate top by the amount of his height as explained here:
[{% imgcap center /images/pure-css3-turnover-effect-animation-of-a-button-without-sprites/explanation.png 400 53 The animation explanation - click to zoom %}](/images/pure-css3-turnover-effect-animation-of-a-button-without-sprites/explanation.png)

So basically we need to have a fixed height and use a css transition to move the div up by his whole height.
{% codeblock lang:scss %}
@mixin article-footer($height) {
    article footer {
        // Setting the viewport height
        height: $height;
        div, a {
            cursor: pointer;
            position: relative;
            display: block;ù
            // Setting the single div and the anchor to the same height equal to the viewport
            height: $height;
            // Centering the text
            line-height: $height;
            &.full-article {
                background-color: rgba(170,170,170,0.2);
            }
            &.full-article-hover {
                background-color: rgba(170,170,170,0.5);
            }
        }
    }
}
{% endcodeblock %}
You can see that I've wrapped all inside a `mixin` so I can easily use one-line of code to sett the different buttons height based on the viewport of the user's browser.
{% codeblock lang:scss %}
// The button will be 40px for every resolution
@include article-footer(40px);

@media only screen and (max-height: 650px) {
    // Except if I browse the website with a screen that has a height < 650
    @include article-footer(25px);
}

// ... more media breakpoints ...
{% endcodeblock %}
With [Compass](http://compass-style.org/) I can use one of their mixin to super easily use [CSS3 transitions](http://compass-style.org/reference/compass/css3/transition/), so all I need to do is simply add this code to get the animation effect:

{% codeblock lang:scss %}
// Inside the previous code ...
&.full-article {
    background-color: rgba(170,170,170,0.2);
    // This line will tell which property has to translate
    @include transition-property(top);
    // Tis mixin will set the transition duration
    @include transition-duration(0.5s);
    &:hover {
        // This will trigger the transition and set the 'destination'
        // value of the top attribute on hover
        top: -$height;
    }
}
{% endcodeblock %}

So these **25 lines of SCSS code** make me puking rainbows just because they will be compiled to **60+ lines of CSS code** and basically there's why you should use Compass+SCSS or shoot yourself.
**PEACE!**
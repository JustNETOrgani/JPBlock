<template>
  <div class="home">
    <Head></Head>
    <div v-loading="loadingImgData">
    <p>
      <a @click="prev" href='#'>Previous</a> || <a @click="next" href='#'>Next</a>
    </p>
    <transition-group name='fade' tag='div'>
      <div
       v-for="number in [currentNumber]"
       :key='number'
       >
         <img
             :src="currentImage" alt="App Banner Image"
             id="carouselImg"
             v-on:mouseover="stopRotation"
             v-on:mouseout="startRotation"
             />
    </div>
  </transition-group>
</div>
    <Footer></Footer>
  </div>
</template>

<script>
// @ is an alias to /src
import Head from '@/components/header'
import Footer from '@/components/Footer'

export default {
  // name: 'Home',
  data () {
    return {
      loadingImgData: false,
      images: [], // Array to hold carousel images.
      currentNumber: 0,
      timer: null
    }
  },
  components: {
    Head,
    Footer
  },
  created () {
    this.loadingImgData = true
    this.images.push('../assets/imgs/backgroundImg.png', '../assets/imgs/bannerOne.jpg', '../assets/imgs/submitPaper.jpg', '../assets/imgs/anotherBkImg.png', '../assets/imgs/bannerFour.jpg')
    // this.images.push({ id: 1, image: '../assets/imgs/backgroundImg.png' }, { id: 2, image: '../assets/imgs/bannerOne.jpg' }, { id: 3, image: '../assets/imgs/submitPaper.jpg' })
    this.startRotation()
    this.loadingImgData = false
  },
  methods: {
    startRotation: function () {
      this.timer = setInterval(this.next, 3000)
    },

    stopRotation: function () {
      clearTimeout(this.timer)
      this.timer = null
    },
    next: function () {
      this.currentNumber += 1
    },
    prev: function () {
      this.currentNumber -= 1
    }
  },
  computed: {
    currentImage () {
      const imgIndexToDisplay = this.images[Math.abs(this.currentNumber) % this.images.length]
      console.log('ImgIndexToUse: ', imgIndexToDisplay)
      return this.images[Math.abs(this.currentNumber) % this.images.length]
    }
  }
}
</script>

<style scoped>
 .fade-enter-active, .fade-leave-active {
  transition: all 0.8s ease;
  overflow: hidden;
  visibility: visible;
  opacity: 1;
  position: absolute;
}
.fade-enter, .fade-leave-to {
  opacity: 0;
  visibility: hidden;
}

#carouselImg{
  width: 100%;
}
</style>

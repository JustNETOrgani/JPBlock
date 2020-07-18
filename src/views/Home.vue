<template>
  <div class="home">
    <Head></Head>
    <div id="sliderDiv" v-loading="loadingImgData">
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
          <p><a @click="prev" href='#'>Previous</a> || <a @click="next" href='#'>Next</a></p>
        </div>
      </transition-group>
  </div>
  <div id="footerDiv">
    <Footer></Footer>
  </div>
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
    // this.images.push('../assets/imgs/backgroundImg.png', '../assets/imgs/anotherBkImg.png')
    // this.images.push('../assets/imgs/backgroundImg.png', '../assets/imgs/bannerOne.jpg', '../assets/imgs/submitPaper.jpg', '../assets/imgs/anotherBkImg.png', '../assets/imgs/bannerFour.jpg')
    // this.images.push({ id: 1, image: '../assets/imgs/background/backgroundImg' }, { id: 2, image: '../assets/imgs/background/anotherBkImg' })
    this.images.push(
      // 'https://cdn.pixabay.com/photo/2018/03/09/18/46/blockchain-3212312__340.jpg',
      'https://cdn.pixabay.com/photo/2013/07/12/13/23/book-146937__340.png',
      'https://egret-plus.eu/wp-content/uploads/2019/07/HCSA-Web-12-Publication-banner-1024x321.jpg',
      'https://www.lawimperial.com/wp-content/uploads/2020/01/slide2.jpg',
      'https://www.iferp.in/blog/wp-content/uploads/2020/03/blog-publish-paper-1.jpg',
      'https://cdn.pixabay.com/photo/2018/03/31/05/06/blockchain-3277335__340.png',
      'https://cdn.pixabay.com/photo/2020/06/10/09/31/bitcoin-5281988__340.jpg',
      'https://cdn.pixabay.com/photo/2017/01/01/20/26/book-1945459__340.jpg',
      // 'https://cdn.pixabay.com/photo/2018/04/25/10/04/blockchain-3349122__340.jpg',
      // 'https://cdn.pixabay.com/photo/2018/08/05/12/04/blockchain-3585482__340.jpg',
      'https://cdn.pixabay.com/photo/2018/09/07/09/10/ethereum-3660218__340.jpg', // Ethereum Pix.
      'https://cdn.pixabay.com/photo/2013/07/18/14/56/open-163976__340.jpg',
      // 'https://cdn.pixabay.com/photo/2015/11/03/09/30/puzzle-1020431__340.jpg',
      // 'https://cdn.pixabay.com/photo/2019/10/25/10/49/audit-4576720__340.jpg',
      // 'https://cdn.pixabay.com/photo/2018/03/20/18/07/bitcoin-3244107__340.jpg',
      'https://cdn.pixabay.com/photo/2018/01/11/21/27/desk-3076954__340.jpg',
      'https://desha.org.bd/assets/uploads/page/original/publications.jpg'
    )
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
      // const imgIndexToDisplay = this.images[Math.abs(this.currentNumber) % this.images.length]
      // console.log('ImgIndexToUse: ', imgIndexToDisplay)
      return this.images[Math.abs(this.currentNumber) % this.images.length]
    }
  }
}
</script>

<style scoped>
#sliderDiv {
  position: absolute;
  top: 4.4em;
  left: 0;
  width: 100%;
  height: 85%;
}

 .fade-enter-active,
.fade-leave-active {
  transition: all 0.9s ease;
  overflow: hidden;
  visibility: visible;
  position: absolute;
  width:100%;
  opacity: 1;
}

.fade-enter,
.fade-leave-to {
  visibility: hidden;
  width:100%;
  opacity: 0;
}

img {
  height:450px;
  width:100%
}

.prev, .next {
  cursor: pointer;
  position: absolute;
  top: 40%;
  width: auto;
  padding: 16px;
  color: white;
  font-weight: bold;
  font-size: 18px;
  transition: 0.7s ease;
  border-radius: 0 4px 4px 0;
  text-decoration: none;
  user-select: none;
}

.next {
  right: 0;
}

.prev {
  left: 0;
}

.prev:hover, .next:hover {
  background-color: rgba(0,0,0,0.9);
}

a{text-decoration: none;}

#footerDiv {
  position: absolute;
  top: 38em;
  left: 0;
  width: 100%;
  height: 14%;
}
</style>

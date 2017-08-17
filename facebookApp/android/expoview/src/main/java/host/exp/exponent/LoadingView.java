// Copyright 2015-present 650 Industries. All rights reserved.

package host.exp.exponent;

import android.animation.ArgbEvaluator;
import android.animation.ObjectAnimator;
import android.content.Context;
import android.graphics.Color;
import android.os.Handler;
import android.util.AttributeSet;
import android.view.View;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;

import com.squareup.picasso.Callback;
import com.squareup.picasso.Picasso;

import org.json.JSONObject;

import host.exp.exponent.analytics.EXL;
import host.exp.exponent.utils.AsyncCondition;
import host.exp.exponent.utils.ColorParser;
import host.exp.expoview.R;

public class LoadingView extends RelativeLayout {

  private static final String TAG = LoadingView.class.getSimpleName();

  private static final String ASYNC_CONDITION_KEY = "loadingViewImage";
  private static final long PROGRESS_BAR_DELAY_MS = 2500;

  ProgressBar mProgressBar;
  ImageView mImageView;
  ImageView mBackgroundImageView;
  View mMadeForExponent;

  private Handler mProgressBarHandler = new Handler();
  private boolean mShowIcon = false;
  private boolean mIsLoading = false;
  private boolean mIsLoadingImageView = false;

  public LoadingView(Context context) {
    super(context);
    init();
  }

  public LoadingView(Context context, AttributeSet attrs) {
    super(context, attrs);
    init();
  }

  public LoadingView(Context context, AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
    init();
  }

  private void init() {
    inflate(getContext(), R.layout.loading_view, this);
    mProgressBar = (ProgressBar) findViewById(R.id.progress_bar);
    mImageView = (ImageView) findViewById(R.id.image_view);
    mBackgroundImageView = (ImageView) findViewById(R.id.background_image_view);
    mMadeForExponent = findViewById(R.id.made_for_exponent);
    setBackgroundColor(Color.WHITE);
    showProgressBar();
  }

  private void showProgressBar() {
    mProgressBarHandler.postDelayed(new Runnable() {
      @Override
      public void run() {
        mProgressBar.setVisibility(View.VISIBLE);
        AlphaAnimation animation = new AlphaAnimation(0.0f, 1.0f);
        animation.setDuration(250);
        animation.setInterpolator(new AccelerateDecelerateInterpolator());
        animation.setFillAfter(true);
        mProgressBar.startAnimation(animation);
      }
    }, PROGRESS_BAR_DELAY_MS);
  }

  private void hideProgressBar() {
    mProgressBarHandler.removeCallbacksAndMessages(null);
    mProgressBar.clearAnimation();

    if (mProgressBar.getVisibility() == View.VISIBLE) {
      AlphaAnimation animation = new AlphaAnimation(1.0f, 0.0f);
      animation.setDuration(250);
      animation.setInterpolator(new AccelerateDecelerateInterpolator());
      animation.setFillAfter(true);
      animation.setAnimationListener(new Animation.AnimationListener() {
        @Override
        public void onAnimationStart(Animation animation) {
        }

        @Override
        public void onAnimationEnd(Animation animation) {
          mProgressBar.setVisibility(View.GONE);
        }

        @Override
        public void onAnimationRepeat(Animation animation) {

        }
      });
      mProgressBar.startAnimation(animation);
    }
  }

  public void setManifest(JSONObject manifest) {
    hideProgressBar();

    if (mIsLoading) {
      return;
    }
    mIsLoading = true;
    mIsLoadingImageView = false;

    if (manifest == null) {
      revealView(mMadeForExponent);
      return;
    }

    JSONObject loadingInfo = manifest.optJSONObject(ExponentManifest.MANIFEST_LOADING_INFO_KEY);
    if (loadingInfo == null) {
      revealView(mMadeForExponent);
      return;
    }

    if (!loadingInfo.optBoolean(ExponentManifest.MANIFEST_LOADING_HIDE_EXPONENT_TEXT_KEY)) {
      revealView(mMadeForExponent);
    }

    if (loadingInfo.has(ExponentManifest.MANIFEST_LOADING_ICON_URL)) {
      mImageView.setVisibility(View.GONE);
      final String iconUrl = loadingInfo.optString(ExponentManifest.MANIFEST_LOADING_ICON_URL);
      mIsLoadingImageView = true;
      Picasso.with(getContext()).load(iconUrl).into(mImageView, new Callback() {
        @Override
        public void onSuccess() {
          revealView(mImageView);
          mIsLoadingImageView = false;
          AsyncCondition.notify(ASYNC_CONDITION_KEY);
        }

        @Override
        public void onError() {
          EXL.e(TAG, "Couldn't load image at url " + iconUrl);
        }
      });
    } else if (loadingInfo.has(ExponentManifest.MANIFEST_LOADING_EXPONENT_ICON_GRAYSCALE)) {
      mImageView.setImageResource(R.drawable.big_logo_dark);

      int grayscale = (int) (255 * loadingInfo.optDouble(ExponentManifest.MANIFEST_LOADING_EXPONENT_ICON_GRAYSCALE, 1.0));
      if (grayscale < 0) {
        grayscale = 0;
      } else if (grayscale > 255) {
        grayscale = 255;
      }
      mImageView.setColorFilter(Color.argb(255, grayscale, grayscale, grayscale));
    } else {
      // Only look at icon color if grayscale field doesn't exist.
      String exponentLogoColor = loadingInfo.optString(ExponentManifest.MANIFEST_LOADING_EXPONENT_ICON_COLOR, null);
      if (exponentLogoColor != null) {
        if (exponentLogoColor.equals("white")) {
          mImageView.setImageResource(R.drawable.big_logo_filled);
        } else if (exponentLogoColor.equals("navy") || exponentLogoColor.equals("blue")) {
          mImageView.setImageResource(R.drawable.big_logo_dark_filled);
        }
      }
    }

    // Should be 1080x1920
    final String backgroundImageUrl = loadingInfo.optString(ExponentManifest.MANIFEST_LOADING_BACKGROUND_IMAGE_URL, null);
    if (backgroundImageUrl != null) {
      Picasso.with(getContext()).load(backgroundImageUrl).into(mBackgroundImageView, new Callback() {
        @Override
        public void onSuccess() {
          revealView(mBackgroundImageView);
        }

        @Override
        public void onError() {
          EXL.e(TAG, "Couldn't load image at url " + backgroundImageUrl);
        }
      });
    }

    String backgroundColor = loadingInfo.optString(ExponentManifest.MANIFEST_LOADING_BACKGROUND_COLOR, null);
    if (backgroundColor != null && ColorParser.isValid(backgroundColor)) {
      ObjectAnimator colorFade = ObjectAnimator.ofObject(this, "backgroundColor", new ArgbEvaluator(), Color.argb(255, 255, 255, 255), Color.parseColor(backgroundColor));
      colorFade.setDuration(300);
      colorFade.start();
    }

    mImageView.setLayerType(View.LAYER_TYPE_HARDWARE, null);
  }

  public void setShowIcon(final boolean showIcon) {
    AsyncCondition.remove(ASYNC_CONDITION_KEY);
    AsyncCondition.wait(ASYNC_CONDITION_KEY, new AsyncCondition.AsyncConditionListener() {
      @Override
      public boolean isReady() {
        return !mIsLoadingImageView;
      }

      @Override
      public void execute() {
        boolean oldShowIcon = mShowIcon;
        mShowIcon = showIcon;

        if (mShowIcon) {
          // Don't interrupt animation if it's already happening
          if (!oldShowIcon) {
            showIcon();
          }
        } else {
          hideIcon();
        }
      }
    });
  }

  private void showIcon() {
    if (!mShowIcon || !mIsLoading) {
      return;
    }

    mImageView.clearAnimation();

    AlphaAnimation animation = new AlphaAnimation(0.0f, 1.0f);
    animation.setStartOffset(50);
    animation.setDuration(700);
    animation.setInterpolator(new AccelerateDecelerateInterpolator());
    animation.setFillAfter(true);
    animation.setAnimationListener(new Animation.AnimationListener() {
      @Override
      public void onAnimationStart(Animation animation) {
        mImageView.setVisibility(View.VISIBLE);
      }

      @Override
      public void onAnimationEnd(Animation animation) {
        hideIcon();
      }

      @Override
      public void onAnimationRepeat(Animation animation) {

      }
    });
    mImageView.startAnimation(animation);
  }

  private void hideIcon() {
    mImageView.clearAnimation();

    AlphaAnimation animation = new AlphaAnimation(1.0f, 0.0f);
    animation.setDuration(700);
    animation.setInterpolator(new AccelerateDecelerateInterpolator());
    animation.setFillAfter(true);
    animation.setAnimationListener(new Animation.AnimationListener() {
      @Override
      public void onAnimationStart(Animation animation) {

      }

      @Override
      public void onAnimationEnd(Animation animation) {
        showIcon();
      }

      @Override
      public void onAnimationRepeat(Animation animation) {

      }
    });
    mImageView.startAnimation(animation);
  }

  public void setDoneLoading() {
    mIsLoading = false;
    AsyncCondition.remove(ASYNC_CONDITION_KEY);
  }

  private void revealView(View view) {
    view.setVisibility(View.VISIBLE);
    AlphaAnimation animation = new AlphaAnimation(0.0f, 1.0f);
    animation.setDuration(300);
    animation.setInterpolator(new AccelerateDecelerateInterpolator());
    animation.setFillAfter(true);
    view.setAnimation(animation);
  }
}
